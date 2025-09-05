import hmac

from flask_restx import Namespace, Resource
from flask import request, url_for, abort
from CTFd.models import Users
from CTFd.utils.user import get_current_user, is_admin
from CTFd.utils.decorators import authed_only

from ...utils import get_current_container, container_password
from ...utils.workspace import start_on_demand_service, reset_home


workspace_namespace = Namespace(
    "workspace", description="Endpoint to manage workspace iframe urls"
)


@workspace_namespace.route("")
class view_desktop(Resource):
    @authed_only
    def get(self):
        user_id = request.args.get("user")
        password = request.args.get("password")
        service = request.args.get("service")

        if not service:
            return {"active": False}

        if user_id and not password and not is_admin():
            abort(403)

        user = get_current_user() if not user_id else Users.query.filter_by(id=int(user_id)).first_or_404()
        container = get_current_container(user)
        if not container:
            return {"active": False}

        if service == "terminal":
            iframe_src = f"/workspace/{service}/"
        else:
            return {"active": False}

        if start_on_demand_service(user, service) is False:
            return {"active": False}

        return {"active": True, "iframe_src": iframe_src, "service": service}


@workspace_namespace.route("/reset_home")
class ResetHome(Resource):
    @authed_only
    def post(self):
        user = get_current_user()

        if not get_current_container(user):
            return {"success": False, "error": "No running container found. Please start a container and try again."}

        try:
            reset_home(user.id)
        except AssertionError as e:
            return {"success": False, "error": f"Reset failed with error: {e}"}

        return {"success": True, "message": "Home directory reset successfully"}
