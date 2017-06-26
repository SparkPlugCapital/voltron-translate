class CreateVoltronTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :voltron_translations do |t|
      t.integer :resource_id
      t.string :resource_type
      t.string :attribute_name
      t.string :locale
      t.text :translation
    end

    add_index :voltron_translations, [:attribute_name, :locale]
  end
end
