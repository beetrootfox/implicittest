from os import urandom

import flask.sessions as si

from flask import (
    Blueprint, flash, g, redirect, render_template, request, url_for, session, abort
)
from werkzeug.exceptions import abort

from isrvpckg.db import get_db

bp = Blueprint('implicit', __name__)

@bp.route('/')
def index():
    return render_template('implicit/index.html')

@bp.route('/questions', methods=('GET', 'POST'))
def questions():
    if request.method == 'POST':
        age = request.form['age']
        earnings = request.form['earnings']
        employment = request.form['employment']
        db = get_db()
        error = None

        if age is None or earnings is None or employment is None:
            flash("All form fields must be filled.")
        else:
            sid = urandom(32)
            print ("AGE: {}, sid: {}".format(age, sid))
            db.execute(
                'INSERT INTO personal (id, age, earnings, employment) VALUES (?, ?, ?, ?)',
                (sid, age, earnings, employment)
            )
            db.commit()
            session.clear()
            session['user_id'] = sid
            return redirect(url_for('implicit.test'))
    return render_template('implicit/questions.html')

@bp.route('/test', methods=('GET', 'POST'))
def test():
    if 'user_id' not in session:
        return redirect(url_for('implicit.index'))
    if request.method == 'POST':
        json = request.get_json()
        db = get_db()
        for record in json:
            db.execute(
                'INSERT INTO test (word, rule, time, correct, sessionid) VALUES (?, ?, ?, ?, ?)',
                (record['word'], record['rule'], record['time'], record['correct'], session['user_id'])
            )
        db.commit()
        session.clear()
        return redirect(url_for('implicit.index'))
    return render_template('implicit/test.html')


