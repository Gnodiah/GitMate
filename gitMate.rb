#!/usr/bin/env ruby

require 'sqlite3'

result = "git log --after='2014-04-29 00:00' --before='2014-04-29 23:59' --author='gnodiah' --numstat | awk 'NF==3 {plus+=$1;minus+=$2;} END {printf(\"" + "+%d, -%d\\n\"" + ", plus, minus)}'"

result = %x[ #{result} ]

result = result.scan(/\w+/)

puts result.first

authors = %x[ git log --format='%aN' | sort -u ].split(/\n/)
p authors

begin
	db = SQLite3::Database.open 'gitmates.db'
	db.execute 'CREATE TABLE IF NOT EXISTS authors( id INTEGER PRIMARY KEY,
																									name VARCHAR(50),
																									email VARCHAR(100))'

	authors.each do |name|
		db.execute "INSERT INTO authors(name) VALUES('#{name}')"
	end

  db.execute 'CREATE TABLE IF NOT EXISTS code_lines( id INTEGER NOT NULL PRIMARY KEY,
                                                     user_id INTEGER NOT NULL FOREIGN KEY REFERENCES authors(id),
                                                     addtion INTEGER,
                                                     deletion INTEGER)'
rescue SQLite3::Exception => e
	puts 'Exception occured'
	puts e
ensure
	db.close if db
end
