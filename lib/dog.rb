# frozen_string_literal: true

class Dog
  attr_reader :id
  attr_accessor :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
		CREATE TABLE dogs(
			id INTEGER PRIMARY KEY,
			name TEXT,
			breed TEXT
		);
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
		DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
		SELECT *
		FROM dogs
		WHERE id = ?
		LIMIT 1
    SQL

    row = DB[:conn].execute(sql, id).first
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_or_create_by(attributes)
    sql = <<-SQL
		SELECT *
		FROM dogs
		WHERE name = ? AND breed = ?
		LIMIT 1
    SQL

    row = DB[:conn].execute(sql, attributes[:name], attributes[:breed])

    if row.empty?
      dog = create(attributes)
    else
      row = row[0]
      dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    end
    dog
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
		SELECT *
		FROM dogs
		WHERE name = ?
		LIMIT 1
    SQL

    new_from_db(DB[:conn].execute(sql, name).first)
  end

	def save
		if id 
			update 
		else
			sql = <<-SQL
			INSERT INTO dogs(name, breed)
			VALUES(?, ?)
			SQL

			DB[:conn].execute(sql, name, breed)
			@id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
			self
		end
  end

  def update
    sql = <<-SQL
		UPDATE dogs
		SET name = ?, breed = ?
		WHERE id = ?
    SQL

    DB[:conn].execute(sql, name, breed, id)
  end
end
