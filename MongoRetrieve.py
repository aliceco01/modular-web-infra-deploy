import gridfs
import requests
from pymongo import MongoClient
from main import get_poster_urls


def download_object(urls):
    """ save the images in a binary object named "contents" """
    for nr, url in enumerate(urls):
        r = requests.get(url)
        contents = r.content
        return contents


def mongo_conn():
    try:
        conn = MongoClient(host='127.0.0.1', port=27017)
        print("MongoDB connected", conn)
        return conn.postersDB

    except Exception as e:
        print("Error in mongo connection:", e)


# connects to database "posters"
db = mongo_conn()


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


# download_to_mongo('tt0070800')
# download_to_mongo('tt0070800')
# download_to_mongo('tt2395427')
# download_from_mongo("./pics/test.jpeg", "tt0371746")
# download_from_mongo("./pics/test1.jpeg", "tt0070800")
# download_from_mongo("./pics/test2.jpeg", "tt2395427")

#new_list = ['tt0371746', 'tt0070800', 'tt0115218', 'tt1300854', 'tt1228705', 'tt0837143', 'tt0903135', 'tt1707807',
#            'tt6218010', 'tt0120744', 'tt1233205', 'tt3296908', 'tt0096251', 'tt0206490']

#for key in new_list:
#    try:
#        download_to_mongo(key)
#        download_from_mongo(f'./pics/{key}.jpeg', key)
#    except:
#        print("this movie can't be downloaded for some reason")

# testing ground
