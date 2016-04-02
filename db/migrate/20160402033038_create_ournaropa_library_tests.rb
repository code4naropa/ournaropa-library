class CreateOurnaropaLibraryTests < ActiveRecord::Migration
  def change
    create_table :ournaropa_library_tests do |t|

      t.timestamps null: false
    end
  end
end
