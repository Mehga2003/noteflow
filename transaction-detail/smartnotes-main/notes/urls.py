from django.urls import path

from . import views


urlpatterns = [

    # =========================
    # HOME
    # =========================
    path(
        '',
        views.home,
        name='home'
    ),

    # =========================
    # AUTHENTICATION
    # =========================
    path(
        'register/',
        views.register,
        name='register'
    ),

    path(
        'login/',
        views.user_login,
        name='login'
    ),

    path(
        'logout/',
        views.user_logout,
        name='logout'
    ),

    # =========================
    # PROFILE
    # =========================
    path(
        'profile/',
        views.profile,
        name='profile'
    ),

    # =========================
    # NOTES
    # =========================
    path(
        'notes/',
        views.notes,
        name='notes'
    ),

    path(
        'notes/add/',
        views.add_note,
        name='add_note'
    ),

    path(
        'notes/update/<int:id>/',
        views.update_note,
        name='update_note'
    ),

    path(
        'notes/delete/<int:id>/',
        views.delete_note,
        name='delete_note'
    ),

    # =========================
    # TRANSACTIONS
    # =========================
    path(
        'transactions/',
        views.transactions,
        name='transactions'
    ),

    path(
        'transactions/add/',
        views.add_transaction,
        name='add_transaction'
    ),

    path(
        'transactions/update/<int:id>/',
        views.update_transaction,
        name='update_transaction'
    ),

    path(
        'transactions/delete/<int:id>/',
        views.delete_transaction,
        name='delete_transaction'
    ),

    # =========================
    # CATEGORIES
    # =========================
    path(
        'categories/',
        views.categories,
        name='categories'
    ),

    path(
        'categories/add/',
        views.add_category,
        name='add_category'
    ),

    # =========================
    # ANALYTICS / DASHBOARD
    # =========================
    path(
        'dashboard/',
        views.dashboard,
        name='dashboard'
    ),

    path(
        'analytics/',
        views.analytics,
        name='analytics'
    ),

    # =========================
    # API
    # =========================
    path(
        'github-languages/<str:username>/',
        views.github_languages,
        name='github_languages'
    ),
]