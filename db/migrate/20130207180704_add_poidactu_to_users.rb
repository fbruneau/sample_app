class AddPoidactuToUsers < ActiveRecord::Migration
  def change
    add_column :users, :poidactu, :float
  end
end
