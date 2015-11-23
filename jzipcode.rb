require 'sqlite3'

class JZipCode
  COL_ZIP = 2
  COL_PREF = 6
  COL_CITY = 7
  COL_ADDR = 8

  def initialize(file)
    @file = file
  end

  def make_db(zip)
    return if File.exists?(@file)
    SQLite3::Database.open(@file) do |db|
      db.execute <<-SQL
        CREATE TABLE IF NOT EXISTS zips
          (code TEXT, pref TEXT, city TEXT, addr TEXT, alladdr TEXT)
      SQL

      File.open(file, 'r:shift_jis') do |zip|
        db.execute "BEGIN TRANSACTION"
        zip.each_line do |line|
          columns = line.split(/,/).map{}|col| col.delete('"')}
          code = columns[COL_ZIP]
          pref = columns[COL_PREF]
          city = columns[COL_CITY]
          addr = columns[COL_ADDR]
          all_addr = pref+city+addr
          db.execute "INSERT INTO zips VALUES (?,?,?,?,?)",
            [code, pref, city, addr, all_addr]
        end
        db.execute "COMMIT TRANSACTION"
      end
    end
  end
end
