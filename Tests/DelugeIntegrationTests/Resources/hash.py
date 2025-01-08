import bencoding, hashlib, sys

def torrent_hash(path):
    file = open(path, 'rb')
    dictionary = bencoding.bdecode(file.read())
    info = hashlib.sha1(bencoding.bencode(dictionary[b"info"])).hexdigest()
    print(info)

torrent_hash(sys.argv[1])
