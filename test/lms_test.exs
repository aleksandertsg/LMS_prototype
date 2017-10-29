defmodule LmsTest do
  use ExUnit.Case
  doctest Lms

  setup do
    Lms.Helpers.setup
  end

  describe "bookLists" do
    test "should return book list from system given" do
      assert Lms.bookList("books_test.json") ==
               [%{"ISBN" => "1233112", "id" => 1, "status" => "available",
               "title" => "title1"},
               %{"ISBN" => "12312512", "id" => 2, "status" => "available",
                 "title" => "book2", "blockedBy" => "blocker"},
               %{"ISBN" => "123125132", "id" => 3, "issuedTo" => "someUser",
               "issuedUntil" => "2017-11-05", "status" => "issued", "title" => "issuedBook"}]
    end
  end

  describe "search" do
    test "should return 'Nothing found' if result list is empty" do
      assert Lms.search("somethingthatdoesnotexist","books_test.json") == "Nothing found"
    end

    test "should return result list if search results found" do
      assert Lms.search("","books_test.json") ==
               [%{"ISBN" => "1233112", "id" => 1, "status" => "available",
               "title" => "title1"},
               %{"ISBN" => "12312512", "id" => 2, "status" => "available",
                 "title" => "book2", "blockedBy" => "blocker"},
               %{"ISBN" => "123125132", "id" => 3, "issuedTo" => "someUser",
                 "issuedUntil" => "2017-11-05", "status" => "issued", "title" => "issuedBook"}]
    end

    test "should search by ISBN" do
      assert Lms.search("1233112","books_test.json") ==
               [%{"ISBN" => "1233112", "id" => 1, "status" => "available", "title" => "title1"}]
    end

    test "should search by title name" do
      assert Lms.search("book2","books_test.json") ==
               [%{"ISBN" => "12312512", "id" => 2, "status" => "available",
                 "title" => "book2", "blockedBy" => "blocker"}]
    end

    test "should search by title even if keyword capitalization does not match and keyword incomplete" do
      assert Lms.search("OK2","books_test.json") ==
               [%{"ISBN" => "12312512", "id" => 2, "status" => "available",
                 "title" => "book2", "blockedBy" => "blocker"}]
    end
  end

  describe "blockBook" do
    test "should block book by given id and user name" do
      assert Lms.blockBook(1, "test_user", "books_test.json") == %{"result" =>
                 [%{"ISBN" => "1233112", "blockedBy" => "test_user", "id" => 1,
                    "status" => "available", "title" => "title1"},
                  %{"ISBN" => "12312512", "id" => 2, "status" => "available",
                    "title" => "book2", "blockedBy" => "blocker"},
                  %{"ISBN" => "123125132", "id" => 3, "issuedTo" => "someUser",
                    "issuedUntil" => "2017-11-05", "status" => "issued", "title" => "issuedBook"}]}
    end

    test "should return 'No changes' if wrong book id given" do
      assert Lms.blockBook(1222, "test_user", "books_test.json") == "No changes"
    end
  end


  describe "unblockBook" do
    test "should unblock blocked book by id" do
      assert Lms.unblockBook(2, "books_test.json") == %{"result" =>
              [%{"ISBN" => "1233112", "id" => 1, "status" => "available", "title" => "title1"},
               %{"ISBN" => "12312512", "id" => 2, "status" => "available", "title" => "book2"},
               %{"ISBN" => "123125132", "id" => 3, "issuedTo" => "someUser", "issuedUntil" => "2017-11-05",
                 "status" => "issued", "title" => "issuedBook"}]}
    end

    test "should return 'No changes' if wrong book id given" do
      assert Lms.unblockBook(1222, "books_test.json") == "No changes"
    end
  end


  describe "issueBook" do
    test "should issue book by id" do
      assert Lms.issueBook(1, "theUser", "books_test.json") == %{"result" =>
               [%{"ISBN" => "1233112", "id" => 1, "title" => "title1", "status" => "issued",
                 "issuedTo" => "theUser", "issuedUntil" => "2017-11-05"},
                %{"ISBN" => "12312512", "id" => 2, "status" => "available",
                  "title" => "book2", "blockedBy" => "blocker"},
                %{"ISBN" => "123125132", "id" => 3, "issuedTo" => "someUser", "issuedUntil" => "2017-11-05",
                  "status" => "issued", "title" => "issuedBook"}]}
    end

    test "should return 'No changes' if book is already issued" do
      assert Lms.issueBook(3, "user", "books_test.json") == "No changes"
    end

    test "should return 'No changes' if wrong book id given" do
      assert Lms.issueBook(1222, "user", "books_test.json") == "No changes"
    end
  end

  describe "returnBook" do
    test "should issue book by id" do
      assert Lms.returnBook(3, "someUser", "books_test.json") == %{"result" =>
               [%{"ISBN" => "1233112", "id" => 1, "status" => "available", "title" => "title1"},
                %{"ISBN" => "12312512", "id" => 2, "status" => "available",
                  "title" => "book2", "blockedBy" => "blocker"},
                %{"ISBN" => "123125132", "id" => 3, "status" => "available", "title" => "issuedBook"}]}
    end

    test "should return 'No changes' if person who returns is not whom it was issuedTo" do
      assert Lms.returnBook(3, "user", "books_test.json") == "No changes"
    end

    test "should return 'No changes' if book is already available" do
      assert Lms.returnBook(1, "user", "books_test.json") == "No changes"
    end

    test "should return 'No changes' if wrong book id given" do
      assert Lms.returnBook(1222, "user", "books_test.json") == "No changes"
    end
  end

  describe "myIssuedBook" do
    test "should return empty list if user given is not issued any book" do
      assert Lms.myIssuedBooks("user", "books_test.json") == []
    end

    test "should return list fo issued books to given user" do
      assert Lms.myIssuedBooks("someUser", "books_test.json") ==
               [%{"ISBN" => "123125132", "id" => 3, "issuedTo" => "someUser", "issuedUntil" => "2017-11-05",
               "status" => "issued", "title" => "issuedBook"}]
    end
  end


  describe "addBook" do
    test "should add new book to list" do
      assert Lms.addBook("12125", "newbook", "books_test.json") == %{"result" =>
               [%{"ISBN" => "12125", "id" => 4,
                 "status" => "available", "title" => "newbook"},
                %{"ISBN" => "1233112", "id" => 1, "status" => "available",
                 "title" => "title1"},
                %{"ISBN" => "12312512", "id" => 2, "status" => "available",
                  "title" => "book2", "blockedBy" => "blocker"},
                %{"ISBN" => "123125132", "id" => 3, "issuedTo" => "someUser",
                  "issuedUntil" => "2017-11-05", "status" => "issued", "title" => "issuedBook"}]}
    end

    test "should return 'No changes' if empty title given" do
      assert Lms.addBook("12125", "", "books_test.json") == "No changes"
    end

    test "should return 'No changes' if empty ISBN given" do
      assert Lms.addBook("", "newtitle", "books_test.json") == "No changes"
    end
  end

  describe "removeBook" do
    test "should remove book by given id" do
      assert Lms.removeBook(3, "books_test.json") == %{"result" =>
               [%{"ISBN" => "1233112", "id" => 1, "status" => "available",
                  "title" => "title1"},
                %{"ISBN" => "12312512", "id" => 2, "status" => "available",
                  "title" => "book2", "blockedBy" => "blocker"}]}

    end

    test "should return 'No changes' if book id given does not exist" do
      assert Lms.removeBook(4, "books_test.json") == "No changes"
    end
  end

end
