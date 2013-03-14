class AddAttachmentsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cv_file_name, :string
		add_column :users, :cv_content_type, :string
    add_column :users, :cv_file_size, :int
    add_column :users, :cv_updated_at, :int
  end
end
