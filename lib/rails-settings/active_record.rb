ActiveRecord::Base.class_eval do
  def self.has_settings
    class_eval do
      def settings
        ScopedSettings.for_target(self)
      end

      def self.settings
        ScopedSettings.for_target(self)
      end

      def settings=(hash)
        hash.each { |k,v| settings[k] = v }
      end

      after_destroy { |user| user.settings.target_scoped.delete_all }

      scope :with_settings, lambda {
        joins("JOIN settings ON (settings.target_id = #{self.table_name}.#{self.primary_key} AND settings.target_type = '#{self.base_class.name}')")
        .select("DISTINCT #{self.table_name}.*")
      }

      scope :with_settings_for, lambda { |var|
        joins("JOIN settings ON (settings.target_id = #{self.table_name}.#{self.primary_key} AND settings.target_type = '#{self.base_class.name}') AND settings.var = '#{var}'")
      }

      scope :without_settings, lambda {
        joins("LEFT JOIN settings ON (settings.target_id = #{self.table_name}.#{self.primary_key} AND settings.target_type = '#{self.base_class.name}')")
        .where('settings.id' => nil)
      }

      scope :without_settings_for, lambda { |var|
        joins("LEFT JOIN settings ON (settings.target_id = #{self.table_name}.#{self.primary_key} AND settings.target_type = '#{self.base_class.name}') AND settings.var = '#{var}'")
        .where('settings.id' => nil)
      }
    end
  end
end
