import hashlib
h = hashlib.new('sha1')
h.update(b"dud5@ska!!")
print(h.hexdigest())