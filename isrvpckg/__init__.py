import os

from flask import Flask


def create_app(test_config=None):
    # create and configure the app
    app = Flask(__name__, instance_relative_config=True)
    app.config.from_mapping(
        DATABASE=os.path.join(app.instance_path, 'data.sqlite'),
    )

    app.config.from_pyfile('app.cfg')

    # ensure the instance folder exists
    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    from . import db
    db.init_app(app)

    from . import implicit
    app.register_blueprint(implicit.bp)
    app.add_url_rule('/', endpoint='index')

    return app
