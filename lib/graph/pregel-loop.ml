export function _applyWrites<Cc extends Record<string, BaseChannel>>(
  channels: Cc,
  tasks: WritesProtocol<keyof Cc>[],
): Set<string> {


  // Filter out non instances of BaseChannel
  const onlyChannels = getOnlyChannels(channels);


  }

  const pendingWriteTaskIdsByChannel = {} as Record<keyof Cc, string[]>;
  for (const task of tasks) {
    const taskId = (task as { id?: string }).id ?? "";
    for (const [chan, val] of task.writes) {
      if (IGNORE.has(chan)) {
        // do nothing
      } else if (chan in onlyChannels) {
        pendingWritesByChannel[chan] ??= [];
        pendingWritesByChannel[chan].push(val);
      }
    }
  }

  const updatedChannels: Set<string> = new Set();
  // Apply writes to channels
  for (const [chan, vals] of Object.entries(pendingWritesByChannel)) {
    if (chan in onlyChannels) {
      const channel = onlyChannels[chan];
      let updated;
      try {
        updated = channel.update(vals);
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
      } catch (e: any) {
        if (e.name === InvalidUpdateError.unminifiable_name) {
          const wrappedError = new InvalidUpdateError(
            `Invalid update for channel "${chan}" with values ${JSON.stringify(
              vals
            )}: ${e.message}`
          );
          wrappedError.lc_error_code = e.lc_error_code;
          throw wrappedError;
        } else {
          throw e;
        }
      }

        // unavailable channels can't trigger tasks, so don't add them
        if (channel.isAvailable()) updatedChannels.add(chan);
      }
    }
  }

  return updatedChannels;
}
export function _prepareNextTasks<
  Nn extends StrRecord<string, PregelNode>,
  Cc extends StrRecord<string, BaseChannel>,
>(
  pendingWrites: [string, string, unknown][] | undefined,
  processes: Nn,
  channels: Cc,
  config: RunnableConfig,
  forExecution: false,
  extra: NextTaskExtraFieldsWithoutStore
): Record<string, PregelTaskDescription>;


async tick(params: { inputKeys?: string | string[] }): Promise<boolean> {
    if (this.store && !this.store.isRunning) {
      await this.store?.start();
    }
    const { inputKeys = [] } = params;
    if (this.status !== "pending") {
      throw new Error(
        `Cannot tick when status is no longer "pending". Current status: "${this.status}"`
      );
    }
    if (![INPUT_DONE, INPUT_RESUMING].includes(this.input)) {
      await this._first(inputKeys);
    } else if (this.toInterrupt.length > 0) {
      this.status = "interrupt_before";
      throw new GraphInterrupt();
    } else if (
      Object.values(this.tasks).every((task) => task.writes.length > 0)
    ) {
      const finishTaskList = Object.values(this.tasks);
      // finish superstep
      const writes = finishTaskList.flatMap((t) => t.writes);
      // All tasks have finished
      this.updatedChannels = _applyWrites(
        this.channels,
        finishTaskList,
        this.triggerToNodes
      );
      // produce values output
      const valuesOutput = await gatherIterator(
        prefixGenerator(
          mapOutputValues(this.outputKeys, writes, this.channels),
          "values"
        )
      );
      // after execution, check if we should interrupt
      if (
        shouldInterrupt(this.checkpoint, this.interruptAfter, finishTaskList)
      ) {
        this.status = "interrupt_after";
        throw new GraphInterrupt();
      }

      // unset resuming flag
      if (this.config.configurable?.[CONFIG_KEY_RESUMING] !== undefined) {
        delete this.config.configurable?.[CONFIG_KEY_RESUMING];
      }
    } else {
      return false;
    }
    if (this.step > this.stop) {
      this.status = "out_of_steps";
      return false;
    }

    const nextTasks = _prepareNextTasks(
      this.nodes,
      this.channels,
      this.config,
      true,
      {
        step: this.step,
        manager: this.manager,
        store: this.store,
        stream: this.stream,
        updatedChannels: this.updatedChannels,
      }
    );
    this.tasks = nextTasks;
    let taskList = Object.values(this.tasks);

      this._emit(
        await gatherIterator(
          prefixGenerator(
            mapDebugCheckpoint(
              this.channels,
              this.streamKeys,
              taskList,
              this.outputKeys
            ),
            "checkpoints"
          )
        )
      );
    }

    if (taskList.length === 0) {
      this.status = "done";
      return false;
    }
   // if there are pending writes from a previous loop, apply them
    if (this.skipDoneTasks && this.checkpointPendingWrites.length > 0) {
      for (const [tid, k, v] of this.checkpointPendingWrites) {
        if (
          k === ERROR ||
          k === ERROR_SOURCE_NODE ||
          k === INTERRUPT ||
          k === RESUME
        ) {
          continue;
        }
        const task = taskList.find((t) => t.id === tid);
        if (task) {
          task.writes.push([k, v]);
        }
      }
     taskList = Object.values(this.tasks);
      for (const task of taskList) {
        if (task.writes.length > 0) {
          this._outputWrites(task.id, task.writes, true);
        }
      }
    }
    // if all tasks have finished, re-tick
    if (taskList.every((task) => task.writes.length > 0)) {
      return this.tick({ inputKeys });
    }


    if (this.stream.modes.has("tasks") || this.stream.modes.has("debug")) {
      const debugOutput = await gatherIterator(
        prefixGenerator(mapDebugTasks(taskList), "tasks")
      );
      this._emit(debugOutput);
    }

    return true;
  }
