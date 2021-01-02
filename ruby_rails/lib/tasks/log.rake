# reference from [stack over flow](https://stackoverflow.com/questions/4100512/is-it-possible-to-output-the-sql-change-scripts-that-rake-dbmigrate-produces)
namespace :db do
    desc 'Make migration with output'
    task(:migrate_with_sql => :environment) do
      ActiveRecord::Base.logger = Logger.new(STDOUT)
      Rake::Task['db:migrate'].invoke
    end
end