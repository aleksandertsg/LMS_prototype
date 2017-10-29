ExUnit.start()

defmodule Lms.Helpers do
  def setup do
    backup = File.read!("books_test_backup.json")
    File.write!("books_test.json", backup)
  end
end