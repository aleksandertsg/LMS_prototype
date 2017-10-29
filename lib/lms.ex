defmodule Lms do

  def search(keyword, sys \\ "books.json") do
    searchkey = String.downcase(keyword)

    result = (searchByTitle(searchkey, sys) ++ searchByISBN(searchkey, sys)) |> Enum.uniq

    if (result == []) do
      "Nothing found"
    else
      result
    end
  end

  def searchByTitle(keyword, sys) do
    bookList(sys) |> Enum.filter(fn(x) -> String.contains?(String.downcase(x["title"]), keyword) end)
  end

  def searchByISBN(keyword, sys) do
    bookList(sys) |> Enum.filter(fn(x) -> String.contains?(String.downcase(x["ISBN"] ), keyword) end)
  end

  def bookList(sys \\ "books.json") do
    dbresponse = Poison.Parser.parse!(File.read! sys)
    dbresponse["result"]
  end

  def blockBook(bookId, user, sys \\ "books.json") do
    books = bookList(sys)
    result = books |> Enum.map(fn(x) -> case x["id"] == bookId do
                                        true -> Map.put(x, "blockedBy", user)
                                        _ -> x
                                        end end)
    completeTask(books, result, sys)
  end

  def unblockBook(bookId, sys \\ "books.json") do
    books = bookList(sys)
    result = books |> Enum.map(fn(x) -> case x["id"] == bookId do
                                        true -> Map.delete(x, "blockedBy")
                                        _    -> x
                                        end end)
    completeTask(books, result, sys)
  end

  def issueBook(bookId, user, sys \\ "books.json") do
    books = bookList(sys)
    result = books |> Enum.map(fn(x) -> case x["id"] == bookId && x["status"] == "available" do
                                          true -> x
                                                  |> Map.put("issuedTo", user)
                                                  |> Map.put("issuedUntil", Date.add(Date.utc_today(), 7))
                                                  |> Map.put("status", "issued")
                                          _    -> x
                                        end end)
    completeTask(books, result, sys)
  end

  def returnBook(bookId, user, sys \\ "books.json") do
    books = bookList(sys)
    result = books |> Enum.map(fn(x) -> case x["id"] == bookId && x["status"] == "issued" && x["issuedTo"] == user do
                                          true -> x
                                                  |> Map.delete("issuedTo")
                                                  |> Map.delete("issuedUntil")
                                                  |> Map.put("status", "available")
                                          _    -> x
                                        end end)
    completeTask(books, result, sys)
  end

  def completeTask(initial, result, sys \\ "books.json") do
    if (result == initial) do
      "No changes"
    else
      result = Poison.encode!(%{"result": result})
      File.write!(sys, result)
      Poison.decode!(result)
    end
  end

  def myIssuedBooks(user, sys \\ "books.json") do
    bookList(sys) |> Enum.filter(fn(x) -> x["issuedTo"] == user end)
  end

  def addBook(isbn, title, sys \\ "books.json") do
    books = bookList(sys)
    if (isbn == "" || title == "") do
      completeTask(books, books, sys)
    else
      lastId = books |> Enum.map(fn(x) -> x["id"] end) |> Enum.max
      newBooks = [%{"ISBN": isbn, "title": title, "status": "available", id: lastId + 1 } | books]
      completeTask(books, newBooks, sys)
    end
  end

  def removeBook(bookId, sys \\ "books.json") do
    books = bookList(sys)
    result = books |> Enum.filter(fn(x) -> x["id"] != bookId end)
    completeTask(books, result, sys)
  end

end
