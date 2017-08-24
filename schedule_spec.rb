require './schedule'

describe Schedule do
  let(:initial_intervals) { [] }
  let(:schedule) { described_class.new(initial_intervals) }

  describe '#add' do
    subject { schedule.add(new_interval) }

    context 'when the list is empty' do
      let(:new_interval) { [1, 5] }

      it { is_expected.to eq([[1, 5]]) }
    end

    context 'when the list has later interval' do
      let(:initial_intervals) { [[3, 4]] }
      let(:new_interval) { [1, 2] }

      it { is_expected.to eq([[1, 2], [3, 4]]) }
    end

    context 'when the list has earlier interval' do
      let(:initial_intervals) { [[1, 2]] }
      let(:new_interval) { [3, 4] }

      it { is_expected.to eq([[1, 2], [3, 4]]) }
    end

    context 'when the list has intervals that fall into the new one' do
      let(:initial_intervals) { [[1, 2], [3, 4]] }
      let(:new_interval) { [0, 5] }

      it { is_expected.to eq([[0, 5]]) }
    end

    context 'when the list has intervals that partially overlap with the new one' do
      let(:initial_intervals) { [[1, 3], [4, 6]] }
      let(:new_interval) { [2, 5] }

      it { is_expected.to eq([[1, 6]]) }
    end

    context 'when the new interval falls between existing intervals' do
      let(:initial_intervals) { [[1, 2], [5, 6]] }
      let(:new_interval) { [3, 4] }

      it { is_expected.to eq([[1, 2], [3, 4], [5, 6]]) }
    end
  end

  describe '#remove' do
    subject { schedule.remove(exclude_interval) }

    context 'when empty schedule' do
      let(:exclude_interval) { [1, 2] }

      it { is_expected.to eq([]) }
    end

    context 'when interval is excluded from an existing interval' do
      let(:initial_intervals) { [[1, 10]] }
      let(:exclude_interval) { [3, 4] }

      it { is_expected.to eq([[1, 3], [4, 10]]) }
    end

    context 'when interval is excluded from an existing interval and it covers the whole schedule' do
      let(:initial_intervals) { [[3, 4]] }
      let(:exclude_interval) { [1, 10] }

      it { is_expected.to eq([]) }
    end

    context 'when interval is excluded from existing interval at the beginning' do
      let(:initial_intervals) { [[2, 4], [5, 10]] }
      let(:exclude_interval) { [1, 3] }

      it { is_expected.to eq([[3, 4], [5, 10]]) }
    end

    context 'when interval is excluded from two existing intervals at the beginning' do
      let(:initial_intervals) { [[1, 4], [5, 7], [8, 10]] }
      let(:exclude_interval) { [3, 6] }

      it { is_expected.to eq([[1, 3], [6, 7], [8, 10]]) }
    end

    context 'when interval is excluded from last existing interval at the end' do
      let(:initial_intervals) { [[1, 2], [3, 5]] }
      let(:exclude_interval) { [4, 7] }

      it { is_expected.to eq([[1, 2], [3, 4]]) }
    end

    context 'when interval is excluded from two existing intervals at the end' do
      let(:initial_intervals) { [[1, 2], [3, 5], [6, 8]] }
      let(:exclude_interval) { [4, 7] }

      it { is_expected.to eq([[1, 2], [3, 4], [7, 8]]) }
    end
  end

  describe 'test case' do
    it 'satisfies the initial test case' do
      schedule = Schedule.new

      schedule.add([1, 5])
      schedule.remove([2, 3])
      schedule.add([6, 8])
      schedule.remove([4, 7])
      schedule.add([2, 7])

      expect(schedule.intervals).to eq([[1, 8]])
    end
  end
end
