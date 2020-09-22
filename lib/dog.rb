class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(name: , breed: , id: nil)
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
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def save
        if self.id
            self.update
        else
            DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)

            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
        end

    end

    def self.create(hash)
        dog = Dog.new(hash)
        dog.save
    end

    def self.new_from_db(row)
        Dog.new(name: row[1], breed: row[2], id: row[0])
    end

    def self.find_by_id(id)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
        Dog.new(name: row[1], breed: row[2], id: row[0])
    end

    def self.find_or_create_by(name:, breed:)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !row.empty?
            self.new_from_db(row[0])
        else
            self.create(name: name, breed: breed)
        end
    end

    def self.find_by_name(name)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)
        self.new_from_db(row[0])
    end

    def update
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
    end
end