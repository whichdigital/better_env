# frozen_string_literal: true
module BetterEnv
  module Rails
    class Value < BetterEnv::Value
      private

      def to_minutes(number)
        number.to_i.minutes
      end
    end
  end
end
