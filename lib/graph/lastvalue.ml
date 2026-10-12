(*
  Stores the last value received, can receive at most one value per step.
 *)
export class LastValue<Value> extends BaseChannel<Value, Value, Value> {
  lc_graph_name = "LastValue";

  // value is an array so we don't misinterpret an update to undefined as no write
  value: [Value] | [] = [];

  constructor(protected initialValueFactory?: () => Value) {
    super();
    if (initialValueFactory) {
      this.value = [initialValueFactory()];
    }
  }


  update(values: Value[]): boolean {
    if (values.length === 0) {
      return false;
    }
    if (values.length !== 1) {
      throw new InvalidUpdateError(
        "LastValue can only receive one value per step.",
        { lc_error_code: "INVALID_CONCURRENT_GRAPH_UPDATE" }
      );
    }

    // eslint-disable-next-line prefer-destructuring
    this.value = [values[values.length - 1]];
    return true;
  }

  get(): Value {
    if (this.value.length === 0) {
      throw new EmptyChannelError();
    }
    return this.value[0];
  }


  isAvailable(): boolean {
    return this.value.length !== 0;
  }
}

/**
 * Stores the last value received, but only made available after finish().
 * Once made available, clears the value.
 */
export class LastValueAfterFinish<Value> extends BaseChannel<
  Value,
  Value,
  [Value, boolean]
> {
  lc_graph_name = "LastValueAfterFinish";

  // value is an array so we don't misinterpret an update to undefined as no write
  value: [Value] | [] = [];

  finished: boolean = false;

  fromCheckpoint(checkpoint?: [Value, boolean]) {
    const empty = new LastValueAfterFinish<Value>();
    if (typeof checkpoint !== "undefined") {
      const [value, finished] = checkpoint;
      empty.value = [value];
      empty.finished = finished;
    }
    return empty as this;
  }

  update(values: Value[]): boolean {
    if (values.length === 0) {
      return false;
    }

    this.finished = false;
    // eslint-disable-next-line prefer-destructuring
    this.value = [values[values.length - 1]];
    return true;
  }

  get(): Value {
    if (this.value.length === 0 || !this.finished) {
      throw new EmptyChannelError();
    }
    return this.value[0];
  }

  checkpoint(): [Value, boolean] | undefined {
    if (this.value.length === 0) return undefined;
    return [this.value[0], this.finished];
  }

  consume(): boolean {
    if (this.finished) {
      this.finished = false;
      this.value = [];
      return true;
    }
    return false;
  }

  finish(): boolean {
    if (!this.finished && this.value.length > 0) {
      this.finished = true;
      return true;
    }
    return false;
  }

  isAvailable(): boolean {
    return this.value.length !== 0 && this.finished;
  }
}
