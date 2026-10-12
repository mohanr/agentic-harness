
(* A configurable PubSub Topic. *)
module Topic<Value> extends BaseChannel<
  Array<Value>,
  Value | Value[],
  Value[] | UniqueTopicCheckpoint<Value>
> {
  lc_graph_name = "Topic";

  unique = false;

  accumulate = false;

  seen: Set<Value>;

  values: Value[];

  constructor(fields?: {
    /**
     * Whether to only add unique values to the topic. If `true`, only unique values (using reference equality) will be added to the topic.
     */
    unique?: boolean;
    /**
     * Whether to accumulate values across steps. If `false`, the channel will be emptied after each step.
     */
    accumulate?: boolean;
  }) {
    super();

    this.unique = fields?.unique ?? this.unique;
    this.accumulate = fields?.accumulate ?? this.accumulate;
    // State
    this.seen = new Set<Value>();
    this.values = [];
  }


  public update(values: Array<Value | Value[]>): boolean {
    let updated = false;
    if (!this.accumulate) {
      updated = this.values.length > 0;
      this.values = [];
    }
    const flatValues = values.flat() as Value[];
    if (flatValues.length > 0) {
      if (this.unique) {
        for (const value of flatValues) {
          if (!this.seen.has(value)) {
            updated = true;
            this.seen.add(value);
            this.values.push(value);
          }
        }
      } else {
        updated = true;
        this.values.push(...flatValues);
      }
    }
    return updated;
  }

  public get(): Array<Value> {
    if (this.values.length === 0) {
      throw new EmptyChannelError();
    }
    return this.values;
  }

  isAvailable(): boolean {
    return this.values.length !== 0;
  }
}

function buildPendingWrites(
  count: number
): [string, string, unknown][] {
  const writes: [string, string, unknown][] = [];
  for (let i = 0; i < count; i += 1) {
    const taskId = `task-${i % 500}`;
    if (i % 4 === 0) {
      writes.push([taskId, RESUME, i]);
    } else if (i % 11 === 0) {
      writes.push([taskId, ERROR, "err"]);
    } else {
      writes.push([taskId, RETURN, i]);
    }
  }
  return writes;
}

function linearScanSuccessfulWrite(
  pendingWrites: [string, string, unknown][],
  taskId: string
): boolean {
  return pendingWrites.some((w) => w[0] === taskId && w[1] !== ERROR);
}

describe("pending writes index", () => {
  it("index successfulWriteTaskIds matches linear scan for many task ids", () => {
    const pendingWrites = buildPendingWrites(12_000);
    const index = _indexPendingWrites(pendingWrites);

    for (let i = 0; i < 500; i += 1) {
      const taskId = `task-${i}`;
      expect(index.successfulWriteTaskIds.has(taskId)).toBe(
        linearScanSuccessfulWrite(pendingWrites, taskId)
      );
    }
  });

  it("index resume values match filter/flatMap for many task ids", () => {
    const pendingWrites = buildPendingWrites(8_000);
    const index = _indexPendingWrites(pendingWrites);

    for (let i = 0; i < 200; i += 1) {
      const taskId = `task-${i}`;
      const expected = pendingWrites
        .filter(([tid, chan]) => tid === taskId && chan === RESUME)
        .flatMap(([, , v]) => v);
      expect((index.resumeByTaskId.get(taskId) ?? []).flat()).toEqual(expected);
    }
  });

    expect(Object.keys(withPrebuilt).sort()).toEqual(
      Object.keys(withoutPrebuilt).sort()
    );
    for (const id of Object.keys(withoutPrebuilt)) {
      expect(withPrebuilt[id]).toEqual(withoutPrebuilt[id]);
    }
  });
});
