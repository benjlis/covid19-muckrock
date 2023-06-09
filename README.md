# covid19-muckrock
Scripts for preprocessing and loading of metadata and text for the History Lab-Muckrock COVID-19 Collection

# install instructions
1. clone this repo
2. install requirements:
```
pip install -r requirements.txt
```
3. set environmental variables `MR_USER` and `MR_PSWD` to a DocumentCloud account with access to the _History Lab COVID-19 Archive_ project
```
export MR_USER=<muckrock_username>
export MR_PSWD=<muckrock_password>
```
4. run the downloader:
```
python metadata_download.py
```
