from msal import PublicClientApplication
app = PublicClientApplication(
    "312435a5-4dd6-40f8-a606-49bbb30c254d",
    authority="https://login.microsoftonline.com/organizations/"
    )

result = None  # It is just an initial value. Please follow instructions below.

# We now check the cache to see
# whether we already have some accounts that the end user already used to sign in before.
accounts = app.get_accounts()

print(accounts)

if accounts:
    # If so, you could then somehow display these accounts and let end user choose
    print("Pick the account you want to use to proceed:")
    for a in accounts:
        print(a["username"])
    # Assuming the end user chose this one
    chosen = accounts[0]
    # Now let's try to find a token in cache for this account
    result = app.acquire_token_silent(["your_scope"], account=chosen)

if not result:
    # So no suitable token exists in cache. Let's get a new one from Azure AD.
    result = app.acquire_token_by_one_of_the_actual_method(..., scopes=["User.Read"])
if "access_token" in result:
    print(result["access_token"])  # Yay!
else:
    print(result.get("error"))
    print(result.get("error_description"))
    print(result.get("correlation_id"))  # You may need this when reporting a bug