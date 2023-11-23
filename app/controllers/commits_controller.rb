class CommitsController < ApplicationController
  def show
    owner = params[:owner]
    repository = params[:repository]
    commit_sha = params[:commit_sha]
    client = Octokit::Client.new(per_page: 100)
    commit = client.commit("#{owner}/#{repository}", commit_sha)
    parent_commit_sha = commit.parents.first&.sha
    author = commit.commit.author.name
    message = commit.commit.message
    files = []

    find_commit_files(commit, files)

    commit_time = commit.commit.author.date

    render json: { owner: owner, repository: repository, commit_sha: commit_sha, author: author, message: message, files: files, commit_time: commit_time, parent_commit_sha: parent_commit_sha }
  end

  private 

  def find_commit_files(commit, files)
    commit.files.each do |f|
      unless f.patch.nil?
        lines = []
        i1 = 0
        i = 0
        f.patch.split("\n").each do |f1|
          plus = f1.starts_with?("+")
          minus = f1.starts_with?("-")
    
          regex = /^.*@@/
          match = regex.match(f1)

          # update index

          if match
            header = match.to_s  
            matches = header.match(/@@ -(\d+),\d+ \+(\d+),\d+ @@/)
            i = matches[1].to_i  
            i1 = matches[2].to_i  
          end

          # set lines according to index also return + or - with response for display color changes on front end
          
          lines << [
            (minus & !match ? i.to_s : " ") + (!minus && !plus  & !match ? i.to_s : "") + "" + (plus & !match ? i1.to_s : " ") + (!minus && !plus & !match ? i1.to_s : "") + f1,
            (minus  & !match ? '-' : '') + (plus  & !match ? '+' : '')
          ]

          # update index according to remove and add files

          if !plus & !minus & !match
            i += 1
            i1 += 1
          elsif !plus & !match & minus 
            i += 1
          elsif !minus & !match & plus
            i1 += 1
          end

        end
        files << [f.filename, lines]
      end    
    end  
  end
end