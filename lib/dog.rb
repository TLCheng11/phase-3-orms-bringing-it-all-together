require "pry"

DB = {:conn => SQLite3::Database.new("db/dogs.db")}

class Dog
  # DB = {:conn => SQLite3::Database.new("db/dogs.db")}

  attr_reader :name, :breed, :id
  attr_writer :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
              id INTEGER PRIMARY KEY,
              name TEXT,
              breed TEXT
            )
          SQL
    
    DB[:conn].execute(sql)
    test = ("SELECT tbl_name FROM sqlite_master WHERE type='table' AND tbl_name='dogs';")
    # binding.pry
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed)

    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    self
  end

  def self.create(name:, breed:)
    self.new(name: name, breed: breed).save
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.all
    sql = "SELECT * FROM dogs"

    DB[:conn].execute(sql).map {|row| self.new_from_db(row)}
  end

  def self.find_by_name(name)
    sql = <<-SQL
            SELECT * FROM dogs
            WHERE dogs.name == "#{name}"
          SQL
    # binding.pry
    self.new_from_db(DB[:conn].execute(sql)[0])
  end

  def self.find(id)
    sql = <<-SQL
            SELECT * FROM dogs
            WHERE dogs.id == #{id}
          SQL

    self.new_from_db(DB[:conn].execute(sql)[0])
  end

end
