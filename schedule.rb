class Schedule
  attr_reader :intervals

  def initialize(initial_intervals = [])
    @intervals = initial_intervals
  end

  def add(interval)
    return intervals << interval if intervals.empty?

    low_index = find(interval[0]).as_low_index
    high_index = find(interval[1]).as_high_index

    deleted = intervals.slice!(low_index..high_index)
    new_interval =
      if deleted.empty?
        interval
      else
        [[deleted.first[0], interval[0]].min, [deleted.last[1], interval[1]].max]
      end

    if low_index < intervals.size
      intervals.insert(low_index, new_interval)
    else
      intervals << new_interval
    end

    intervals
  end

  def remove(interval)
    return intervals if intervals.empty?

    low_index = find(interval[0]).as_low_index
    high_index = find(interval[1]).as_high_index

    deleted = intervals.slice!(low_index..high_index)

    new_low_index = low_index >= intervals.size ? -1 : low_index
    insert_right_shard(new_low_index, deleted.last, interval) if deleted.last

    new_low_index = low_index >= intervals.size ? -1 : low_index
    insert_left_shard(new_low_index, deleted.first, interval) if deleted.first

    intervals
  end

  private

  class InInterval < Struct.new(:intervals, :index)
    def as_low_index
      index
    end

    def as_high_index
      index
    end
  end

  class BeforeInterval < Struct.new(:intervals, :index)
    def as_low_index
      index
    end

    def as_high_index
      index == 0 ? -intervals.size - 1 : index - 1
    end
  end

  class AfterInterval < Struct.new(:intervals, :index)
    def as_low_index
      index + 1
    end

    def as_high_index
      index
    end
  end

  def insert_left_shard(index, deleted_interval, interval)
    lo = deleted_interval[0]
    hi = [deleted_interval[1], interval[0]].min

    if lo < hi
      intervals.insert(index, [lo, hi])
    end
  end

  def insert_right_shard(index, deleted_interval, interval)
    lo = [deleted_interval[0], interval[1]].max
    hi = deleted_interval[1]

    if lo < hi
      intervals.insert(index, [lo, hi])
    end
  end

  def find(value)
    lo = 0
    hi = intervals.size - 1

    while lo < hi do
      m = (lo + hi) / 2

      if intervals[m][0] <= value && value <= intervals[m][1]
        return InInterval.new(intervals, m)
      elsif intervals[m][0] > value
        hi = m
        break if m == 0
        hi -= 1
      else
        lo = m
        break if m == intervals.size - 1
        lo += 1
      end
    end

    if intervals[lo][0] <= value && value <= intervals[lo][1]
      InInterval.new(intervals, lo)
    elsif value < intervals[lo][0]
      BeforeInterval.new(intervals, lo)
    else
      AfterInterval.new(intervals, lo)
    end
  end
end
