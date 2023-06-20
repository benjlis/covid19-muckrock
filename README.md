# covid19-muckrock
Scripts for preprocessing and downloading of metadata and text for the History Lab-Muckrock COVID-19 Collection

# install instructions
1. clone this repo
2. install requirements:
```
pip install -r requirements.txt
```
3. Set environmental variables `MR_USER` and `MR_PSWD` to a DocumentCloud account with access to the _History Lab COVID-19 Archive_ project. Set `PG*` enviornmental variables to the PostgreSQL FOIArchive database.
```
export MR_USER=<muckrock_username>
export MR_PSWD=<muckrock_password>
export PGUSER=<postgres_username>
export PGPASSWORD=<postgres_password>
export PGHOST=<postgres_host>
```
4. run the downloaders:
```
python metadata_download.py
python text_download.py
```
* The metadata program downloads data to a CSV file. SQL scripts then are used to load the data.
* The text program downloads data directly into a database table.