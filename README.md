# Redmine Issue Query Set

Adds selected issues to a saved query. Their numbers are appended to the query's issue list with commas.

[Türkçe](README.tr.md)

## Features

* On the issue list, select issues and right-click **Add to query**. A small popup searches queries and can update several at once.
* Filter the query list by all queries you can edit, or only this project's queries.
* Existing numbers stay in order. New numbers are added at the end. Duplicates and extra commas are removed.

Example: a query that already contains `32310,32316` receives `32322` and is saved as `32310,32316,32322`.

## Required Redmine version

* 4.2.x ~ 6.x

No extra gem, no asset compilation, and no database migration. You can update a query only when Redmine already lets you edit it.

## Install

```bash
cd /home/niltek/redmine/app/plugins
sudo -u niltek git clone https://github.com/oten52/Redmine.IssueQuerySet.git
docker restart redmine-redmine-1
```

The directory name can stay `Redmine.IssueQuerySet`.

## Update

```bash
cd /home/niltek/redmine/app/plugins/Redmine.IssueQuerySet
sudo -u niltek git pull
docker restart redmine-redmine-1
```
