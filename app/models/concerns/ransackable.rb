module Ransackable
  extend ActiveSupport::Concern

  class_methods do
    def ransackable_attributes(_auth_object = nil)
      @ransackable_attributes ||= begin
        blacklist = %w[
          password token secret encrypted salt reset otp
        ]

        (column_names + _ransackers.keys + _ransack_aliases.keys + attribute_aliases.keys)
          .uniq
          .reject { |attr| blacklist.any? { |word| attr.match?(/#{word}/i) } }
      end
    end

    def ransackable_associations(_auth_object = nil)
      @ransackable_associations ||= reflect_on_all_associations.map { |a| a.name.to_s }
    end
  end
end
