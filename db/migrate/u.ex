class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.text :avatar
      t.string :nick_name
      t.integer :genre
      t.text :description
      t.text :hobby
      t.integer :status, default: 0
      t.integer :country
      t.boolean :admin, default: false

      t.timestamps
    end
  end
end
