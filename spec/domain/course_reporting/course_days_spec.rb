require 'spec_helper'

describe CourseReporting::CourseDays do

  it '0 for empty dates array' do
    sum.should eq 0
  end

  context 'start_at only' do
    context :half_day do
      it 'afternoon session' do
        sum(build('2014-11-17 13:00')).should eq(0.5)
      end
    end

    context :full_day do
      it 'morning session' do
        sum(build('2014-11-17 10:30')).should eq(1)
      end
    end
  end

  context 'start_at and finish_at on the same day' do
    context :half_day do
      it 'morning session' do
        sum(build('2014-11-17 08:30',
                  '2014-11-17 12:30')).should eq(0.5)
      end

      it 'short morning session' do
        sum(build('2014-11-17 08:30',
                  '2014-11-17 10:30')).should eq(0.5)
      end

      it 'long morning session' do
        sum(build('2014-11-17 06:30',
                  '2014-11-17 12:00')).should eq(0.5)
      end

      it 'short afternoon session' do
        sum(build('2014-11-17 13:30',
                  '2014-11-17 16:30')).should eq(0.5)
      end

      it 'long afternoon session' do
        sum(build('2014-11-17 13:30',
                  '2014-11-17 20:30')).should eq(0.5)
      end

      it 'short midday session' do
        sum(build('2014-11-17 11:30',
                  '2014-11-17 13:30')).should eq(0.5)
      end
    end

    context :day do
      it 'normal session' do
        sum(build('2014-11-17 08:30',
                  '2014-11-17 17:30')).should eq(1)
      end

      it 'long midday session' do
        sum(build('2014-11-17 10:30',
                  '2014-11-17 15:30')).should eq(1)
      end
    end
  end

  context 'start_at and finish_at on the different days' do
    context :day do
      it 'afternoon to morning session' do
        sum(build('2014-11-17 13:30',
                  '2014-11-18 10:30')).should eq(1)
      end
    end

    context :day_and_a_half do
      it 'morning to morning session' do
        sum(build('2014-11-17 10:30',
                  '2014-11-18 10:30')).should eq(1.5)
      end

      it 'afternoon to afternoon session' do
        sum(build('2014-11-17 13:30',
           '2014-11-18 16:30')).should eq(1.5)
      end
    end

    context :two_days do
      it 'morning to afternoon session' do
        sum(build('2014-11-17 10:30',
                  '2014-11-18 16:30')).should eq(2)
      end
    end
  end

  context 'multiple dates' do
    it 'morning session and whole day session, different days' do
      sum([build('2014-11-17 08:30', '2014-11-17 10:30'),
           build('2014-11-18 08:30', '2014-11-18 18:30')]).should eq(1.5)
    end

    it 'morning session and whole day session, same day' do
      sum([build('2014-11-17 08:30', '2014-11-17 10:30'),
           build('2014-11-17 08:30', '2014-11-17 18:30')]).should eq(1.5)
    end

    it 'half day plus a week' do
      sum([build('2014-11-10 22:30'),
           build('2014-11-20 08:30', '2014-11-26 18:30')]).should eq(7.5)
    end
  end



  def sum(dates = nil)
    CourseReporting::CourseDays.new(Array(dates)).sum
  end

  def build(start_at, finish_at = nil)
    Event::Date.new(start_at: Time.zone.parse(start_at),
                    finish_at: finish_at && Time.zone.parse(finish_at))
  end

end
