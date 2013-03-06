class AddTailleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :taille, :float
  end
end
