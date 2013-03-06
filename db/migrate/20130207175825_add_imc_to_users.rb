class AddImcToUsers < ActiveRecord::Migration
  def change
    add_column :users, :imc, :float
  end
end
