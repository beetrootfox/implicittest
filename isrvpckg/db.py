import sqlite3
import json
import click
from flask import current_app, g, url_for
from flask.cli import with_appcontext


def init_app(app):
    app.teardown_appcontext(close_db)
    app.cli.add_command(init_db_command)
    app.cli.add_command(link_resources_command)

def init_db():
    db = get_db()

    with current_app.open_resource('schema.sql') as f:
        db.executescript(f.read().decode('utf8'))

@click.command('init-db')
@with_appcontext
def init_db_command():
    """Clear the existing data and create new tables."""

    init_db()
    click.echo('Initialized the database.')

@click.command('link-resources')
@with_appcontext
def link_resources_command():
    """Replace filenames of images with links."""

    with open('/home/ubuntu/implicittest/isrvpckg/static/test.json', 'r+', encoding='utf-8-sig') as f:
        data = json.load(f)
        new_items = [url_for('static', filename=i) for i in data['items']]
        data['items'] = new_items
        f.seek(0)
        json.dump(data, f, ensure_ascii=False)
        f.truncate()

def get_db():
    if 'db' not in g:
        g.db = sqlite3.connect(
            current_app.config['DATABASE'],
            detect_types=sqlite3.PARSE_DECLTYPES
        )
        g.db.row_factory = sqlite3.Row

    return g.db


def close_db(e=None):
    db = g.pop('db', None)

    if db is not None:
        db.close()

