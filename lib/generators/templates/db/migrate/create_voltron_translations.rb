class CreateVoltronTranslations < ActiveRecord::Migration
  def change
    create_table :voltron_translations do |t|
      t.integer :resource_id
      t.string :resource_type
      t.string :attribute_name
      t.string :locale
      t.text :translation
    end
  end
end
