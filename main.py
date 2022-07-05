from flask import Flask, redirect, url_for, render_template, request, json, Response, send_file
import imdb
import os
from config import KEY
import os.path
import gridfs
import requests
from pathlib import Path
from pymongo import MongoClient
# from bottle import response, route

app = Flask(__name__)

CONFIG_PATTERN = 'http://api.themoviedb.org/3/configuration?api_key={key}'
IMG_PATTERN = 'http://api.themoviedb.org/3/movie/{imdbid}/images?api_key={key}'
LOCAL_DOWNLOAD_DIR_NAME = "pics"


def download_object(urls):
    """ save the images in a binary object named "contents" """
    for nr, url in enumerate(urls):
        r = requests.get(url)
        contents = r.content
        return contents


def _download_images(urls, path='./static'):
    """download all images in list 'urls' to 'path' """

    for nr, url in enumerate(urls):
        if nr == 0:
            r = requests.get(url)
            print(r)
            filetype = r.headers['content-type'].split('/')[-1]
            filename = '{0}_{1}.{2}'.format(movie_id, nr + 1, filetype)
            filepath = os.path.join(path, filename)
            with open(filepath, 'wb') as w:
                w.write(r.content)


def mongo_conn():
    try:
        conn = MongoClient(host="mongodb",
                           port=27017)
        print("MongoDB connected", conn)
        return conn.postersDB

    except Exception as e:
        print("Error in mongo connection:", e)


# connects to database "posters"
db = mongo_conn()

## print("db", db)


# download image from imdb straight into mongo
# takes movie_id as 'str' e.g: 'tt4154796'
def download_to_mongo(movie_id, count=None, outpath='./static'):
    urls = get_poster_urls(movie_id)
    if count is not None:
        urls = urls[:count]
    data = download_object(urls)
    fs = gridfs.GridFS(db)
    fs.put(data, filename=movie_id)
    print("upload complete")


def tmdb_posters(imdbid, count=None, outpath='./static'):
    urls = get_poster_urls(imdbid)
    if count is not None:
        urls = urls[:count]
    _download_images(urls, outpath)


# download_to_mongo("tt0371746")
# first parameter is the download location including the name extension
# second parameter is the file name to search in mongo
def download_from_mongo(download_location, name):
    data = db.fs.files.find_one({'filename': name})
    my_id = data['_id']
    fs = gridfs.GridFS(db)
    outputdata = fs.get(my_id).read()
    output = open(download_location, "wb")
    output.write(outputdata)
    output.close()
    print("Download complete")


def _get_json(url):
    r = requests.get(url)
    return r.json()


def get_poster_urls(imdbid):
    """ return image urls of posters for IMDB id
        returns all poster images from 'themoviedb.org'. Uses the
        maximum available size.
        Args:
            imdbid (str): IMDB id of the movie
        Returns:
            list: list of urls to the images
    """
    config = _get_json(CONFIG_PATTERN.format(key=KEY))
    base_url = config['images']['base_url']
    sizes = config['images']['poster_sizes']

    """
        'sizes' should be sorted in ascending order, so
            max_size = sizes[-1]
        should get the largest size as well.        
    """

    def size_str_to_int(x):
        return float("inf") if x == 'original' else int(x[1:])

    max_size = max(sizes, key=size_str_to_int)

    posters = _get_json(IMG_PATTERN.format(key=KEY, imdbid=imdbid))['posters']
    poster_urls = []
    for poster in posters:
        rel_path = poster['file_path']
        url = "{0}{1}{2}".format(base_url, max_size, rel_path)
        poster_urls.append(url)

    return poster_urls


@app.route("/")
def home():
    return render_template("index.html")


@app.route('/', methods=["POST"])
def search():
    # movie name
    global movie
    movie = request.form['movie']
    ## hostname = "google.com"  # example
    ## response = os.system("ping -c 1 " + hostname)
    return redirect(url_for("results"))


# show the images and results of the search method
@app.route('/search', methods=["GET", "POST"])
def results():
    ia = imdb.IMDb()
    movies_list = ia.search_movie(movie)
    global movie_id
    # my list has the conditions of movies, if true the file exists.
    my_list = []
    movies_id_list = []
    for key in movies_list:
        movies_id_list.append('tt' + key.movieID)

    for movie_id in movies_id_list:
        try:
            if db.fs.files.count_documents({'filename': movie_id}):
                ## print("db1")
                continue
            else:
                ## print("db2")
                download_to_mongo(movie_id)
        except Exception as e:
            print("exception", e)
            continue
    """ This block is extremely important, it makes a list of the possible posters to download"""
    for movie_id in movies_id_list:
        try:
            data = db.fs.files.find_one({'filename': movie_id})
            my_id = data['_id']
            fs = gridfs.GridFS(db)
            my_poster = (fs.get(my_id).read())
            my_poster = len(my_poster)
            if db.fs.files.count_documents({'filename': movie_id}) and my_poster:
                my_list.append(True)
                continue
            else:
                my_list.append(False)
        except:
            my_list.append(False)

    my_zip = list(zip(movies_list, my_list))
    return render_template("search.html", content=my_zip)


@app.route('/search/download', methods=["GET", "POST"])
def download():

    # create the directory if it does not exist
    Path(f"./{LOCAL_DOWNLOAD_DIR_NAME}").mkdir(exist_ok=True)

    # receive Movie ID list
    movie_id_list = request.form.getlist('movieID')
    # downloads all the chosen posters to local machine
    for movie_id in movie_id_list:
        try:
            download_from_mongo(f"./{LOCAL_DOWNLOAD_DIR_NAME}/{movie_id}" + '.jpeg', movie_id)
            path = f'./pics/{movie_id}' + '.jpeg'
            return send_file(path, as_attachment=True)
        except:
            continue
    return render_template("download.html")


@app.route('/posters/<name>')
def show_poster(name):
    data = db.fs.files.find_one({'filename': name})
    my_id = data['_id']
    fs = gridfs.GridFS(db)
    my_poster = fs.get(my_id).read()
    # response.content = 'image/jpeg'
    return my_poster


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5050)

# Dockerization completed
