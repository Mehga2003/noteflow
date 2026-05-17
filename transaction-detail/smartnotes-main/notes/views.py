from django.shortcuts import render
from django.http import HttpResponse

import requests
import logging

logger = logging.getLogger('notes')

from concurrent.futures import ThreadPoolExecutor

from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

from .models import Transaction


# =========================================
# HOME PAGE
# =========================================

def home(request):

    return render(
        request,
        'home.html'
    )


##################################################
# AUTHENTICATION
##################################################

def register(request):

    return HttpResponse(
        "Register Page"
    )


def user_login(request):

    return HttpResponse(
        "Login Page"
    )


def user_logout(request):

    return HttpResponse(
        "Logout Page"
    )


##################################################
# PROFILE
##################################################

def profile(request):

    return HttpResponse(
        "Profile Page"
    )


##################################################
# NOTES
##################################################

def notes(request):

    return HttpResponse(
        "Notes Page"
    )


def add_note(request):

    return HttpResponse(
        "Add Note Page"
    )


def update_note(request, id):

    return HttpResponse(
        f"Update Note {id}"
    )


def delete_note(request, id):

    return HttpResponse(
        f"Delete Note {id}"
    )


##################################################
# TRANSACTIONS WEB PAGES
##################################################

def transactions(request):

    return HttpResponse(
        "Transactions Page"
    )


def add_transaction(request):

    return HttpResponse(
        "Add Transaction"
    )


def update_transaction(request, id):

    return HttpResponse(
        f"Update Transaction {id}"
    )


def delete_transaction(request, id):

    return HttpResponse(
        f"Delete Transaction {id}"
    )


##################################################
# CATEGORIES
##################################################

def categories(request):

    return HttpResponse(
        "Categories Page"
    )


def add_category(request):

    return HttpResponse(
        "Add Category"
    )


##################################################
# DASHBOARD / ANALYTICS
##################################################

def dashboard(request):

    return HttpResponse(
        "Dashboard Page"
    )


def analytics(request):

    return HttpResponse(
        "Analytics Page"
    )


# =========================================
# TRANSACTIONS API
# =========================================

@api_view(['GET', 'POST'])

def transactions_api(request):

    ##################################################
    # GET TRANSACTIONS
    ##################################################

    if request.method == 'GET':

        logger.info(
            "GET Transactions API called"
        )

        transactions = Transaction.objects.all().order_by('-id')

        data = []

        for item in transactions:

            data.append({

                "title":
                    item.title,

                "amount":
                    item.amount,

                "type":
                    item.type,
            })

        return Response(data)

    ##################################################
    # ADD TRANSACTION
    ##################################################

    if request.method == 'POST':

        logger.info(
            f"POST Transaction: {request.data}"
        )

        data = request.data

        transaction = Transaction.objects.create(

            title=data.get("title"),

            amount=data.get("amount"),

            type=data.get("type"),
        )

        return Response({

            "message":
                "Transaction Added",

            "id":
                transaction.id
        })
# =========================================
# GITHUB TOKEN
# =========================================

GITHUB_TOKEN = "YOUR_GITHUB_TOKEN"


headers = {

    "Authorization":
        f"Bearer {GITHUB_TOKEN}",

    "Accept":
        "application/vnd.github+json"
}


# =========================================
# FETCH LANGUAGES
# =========================================

def fetch_languages(language_url):

    try:

        response = requests.get(

            language_url,

            headers=headers,

            timeout=5
        )

        if response.status_code == 200:

            return response.json()

        return {}

    except requests.exceptions.RequestException:

        return {}


# =========================================
# GITHUB LANGUAGES API
# =========================================

@api_view(['GET'])

def github_languages(request, username):

    github_url = (
        f"https://api.github.com/users/{username}/repos?per_page=100"
    )

    try:

        response = requests.get(

            github_url,

            headers=headers,

            timeout=10
        )

        ##################################################
        # USER NOT FOUND
        ##################################################

        if response.status_code == 404:

            return Response(

                {
                    "error":
                        "GitHub user not found"
                },

                status=status.HTTP_404_NOT_FOUND
            )

        ##################################################
        # RATE LIMIT
        ##################################################

        if response.status_code == 403:

            return Response(

                {
                    "error":
                        "GitHub API rate limit exceeded"
                },

                status=status.HTTP_403_FORBIDDEN
            )

        response.raise_for_status()

        repos = response.json()

        ##################################################
        # EMPTY REPOS
        ##################################################

        if not repos:

            return Response(

                {
                    "message":
                        "No repositories found"
                }
            )

        language_totals = {}

        ##################################################
        # LANGUAGE URLS
        ##################################################

        language_urls = [

            repo.get("languages_url")

            for repo in repos

            if repo.get("languages_url")
        ]

        ##################################################
        # FETCH IN PARALLEL
        ##################################################

        with ThreadPoolExecutor(

            max_workers=15

        ) as executor:

            results = executor.map(

                fetch_languages,

                language_urls
            )

            for lang_data in results:

                for language, bytes_used in lang_data.items():

                    language_totals[language] = (

                        language_totals.get(
                            language,
                            0
                        )

                        + bytes_used
                    )

        ##################################################
        # NO LANGUAGE DATA
        ##################################################

        if not language_totals:

            return Response(

                {
                    "message":
                        "No language data found"
                }
            )

        ##################################################
        # PERCENTAGES
        ##################################################

        total_bytes = sum(
            language_totals.values()
        )

        percentages = {

            language: round(

                (bytes_used / total_bytes) * 100,

                2
            )

            for language, bytes_used
            in language_totals.items()
        }

        ##################################################
        # SORT DESC
        ##################################################

        sorted_percentages = dict(

            sorted(

                percentages.items(),

                key=lambda item: item[1],

                reverse=True
            )
        )

        ##################################################
        # FINAL RESPONSE
        ##################################################

        return Response({

            "username":
                username,

            "total_repositories":
                len(repos),

            "languages":
                sorted_percentages
        })

    ##################################################
    # TIMEOUT
    ##################################################

    except requests.exceptions.Timeout:

        return Response(

            {
                "error":
                    "GitHub API timeout"
            },

            status=status.HTTP_408_REQUEST_TIMEOUT
        )

    ##################################################
    # REQUEST ERROR
    ##################################################

    except requests.exceptions.RequestException as e:

        return Response(

            {
                "error":
                    str(e)
            },

            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

    ##################################################
    # UNKNOWN ERROR
    ##################################################

    except Exception as e:

        return Response(

            {
                "error":
                    f"Unexpected error: {str(e)}"
            },

            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )