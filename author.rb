class Author
  def initialize
  end

  def self.code_lines(author)
    # TODO: 要加上git remote update -p;
    result = "cd /home/weihd/Documents/tao800_fire;git log --all --pretty='%H' --after='2014-04-28 00:00' --before='2014-04-28 23:59' --author='#{author}' --numstat | awk 'NF==3 {plus+=$1;minus+=$2;} END {printf(\"" + "+%d, -%d\\n\"" + ", plus, minus)}'"

    result = %x[ #{result} ]

    result.scan(/\w+/)
  end
end
