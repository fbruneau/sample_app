class AddPoididealToUsers < ActiveRecord::Migration
  def change
    add_column :users, :poidideal, :float
  end
end
