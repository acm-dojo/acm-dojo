from flask import Blueprint, Response, render_template, abort

from ..utils.awards import get_belts


belts = Blueprint("pwncollege_belts", __name__)


@belts.route("/belts")
def view_belts():
    return render_template("error.html", error = "Page Not Found")
