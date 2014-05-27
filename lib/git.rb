module Git
	def commits(repo_dir, begin_date, end_date, author_name)
    result = "cd #{repo_dir};git log --all --pretty='%H' --after='#{begin_date} 00:00' --before='#{end_date} 23:59' --author='#{author_name}' | wc -l"

    %x[ #{result} ].to_i
	end

	def all_commits(repo_dir)
		commits(repo_dir, '')
	end

	# http://stackoverflow.com/questions/5188914/how-to-show-first-commit-by-git-log
	def first_commit(repo_dir)
    result = "cd #{repo_dir};git log --all --reverse --pretty='%h %aN %aE %ad' | head -1"

    %x[ #{result} ].split
	end

	def last_commit(repo_dir)
    result = "cd #{repo_dir};git log --all --pretty='%h %aN %aE %ad' -1"

    %x[ #{result} ].split
	end

	def authors(repo_dir)
	end
end
