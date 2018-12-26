from urllib.parse import urlparse, urlunparse

from flask import redirect, request
from isrvpckg import create_app

app = create_app()

@app.before_request
def redirect_to_www():
    urlparts = urlparse(request.url)
    if urlparts.netloc[:4] != 'www.':
        urlparts_list = list(urlparts)
        urlparts_list[1] = 'www.' + urlparts_list[1]
        return redirect(urlunparse(urlparts_list), code=301)

if __name__ == "__main__":
	app.run()
