# OAuth OpenID and SAML

OAuth 2.0 is a framework that controls authorization to a protected resource such as an application or a set of files, while OpenID Connect and SAML are both industry standards for federated authentication. 

Using either OpenID Connect or SAML independently, enterprises can achieve user authentication and deploy single sign-on. Though they both deal with logins, they have different strengths and weaknesses.

- OpenID Connect is built on the OAuth 2.0 protocol and uses an additional JSON Web Token (JWT), called an **ID token**, to standardize areas that OAuth 2.0 leaves up to choice, such as scopes and endpoint discovery. It is specifically focused on user authentication and is widely used to enable user logins on consumer websites and mobile apps.
- SAML is independent of OAuth, relying on an exchange of messages to authenticate in XML SAML format, as opposed to JWT. It is more commonly used to help enterprise users sign in to multiple applications using a single login.

## OAuth 2.0 Flow

![Terrible Pun of the Day Authorization Code Flow](https://d33wubrfki0l68.cloudfront.net/e65239bdbd8b982d8eda9f1da9f486efdb11af1d/1cc5c/assets-jekyll/blog/illustrated-guide-to-oauth-and-oidc/tpotd-authorization-code-flow-f959373be5520c3f3a78fbd0a340c5ea67e75cf27979476cf66670914de5e6ba.jpg)

1. You, the **Resource Owner**, want to allow “Terrible Pun of the Day,” the **Client**, to access your contacts so they can send invitations to all your friends.
2. The **Client** redirects your browser to the **Authorization Server** and includes with the request the **Client ID**, **Redirect URI**, **Response Type**, and one or more **Scopes** it needs.
3. The **Authorization Server** verifies who you are, and if necessary prompts for a login.
4. The **Authorization Server** presents you with a **Consent** form based on the **Scopes** requested by the **Client**. You grant (or deny) permission.
5. The **Authorization Server** redirects back to **Client** using the **Redirect URI** along with an **Authorization Code**.
6. The **Client** contacts the **Authorization Server** directly (does not use the **Resource Owner**’s browser) and securely sends its **Client ID**, **Client Secret**, and the **Authorization Code**.
7. The **Authorization Server** verifies the data and responds with an **Access Token**.
8. The **Client** can now use the **Access Token** to send requests to the **Resource Server** for your contacts.

## OpenID Connect

OAuth 2.0 is designed only for *authorization*, for granting access to data and features from one application to another. [OpenID Connect](https://openid.net/connect/) (OIDC) is a thin layer that sits on top of OAuth 2.0 that adds login and profile information about the person who is logged in. Establishing a login session is often referred to as *authentication*, and information about the person logged in (i.e. the **Resource Owner**) is called *identity*. When an Authorization Server supports OIDC, it is sometimes called an *identity provider*, since it *provides* information about the **Resource Owner** back to the **Client**.

OpenID Connect enables scenarios where one login can be used across multiple applications, also known as *single sign-on* (SSO). For example, an application could support SSO with social networking services such as Facebook or Twitter so that users can choose to leverage a login they already have and are comfortable using.

The OpenID Connect flow looks the same as OAuth. The only differences are, in the initial request, a specific scope of `openid` is used, and in the final exchange the **Client** receives both an **Access Token** and an **ID Token**.

![Terrible Pun of the Day OIDC Example](https://d33wubrfki0l68.cloudfront.net/5e16fd7ccb2302d02db4a34a648ee4a58dbef364/3d4ed/assets-jekyll/blog/illustrated-guide-to-oauth-and-oidc/tpotd-oidc-example-191accef3b901cec19fcbfa3eba7d4a175e3545e60efd656e3aea959a3df4deb.jpg)

An **ID Token** is a specifically formatted string of characters known as a JSON Web Token, or JWT. JWTs are sometimes pronounced “jots.” A JWT may look like gibberish to you and me, but the **Client** can extract information embedded in the JWT such as your ID, name, when you logged in, the **ID Token** expiration, and if anything has tried to tamper with the JWT. The data inside the **ID Token** are called *claims*.

## SAML

**SAML (Security Assertion Markup Language):** You’ve more likely experienced SAML authentication in action in the work environment. For example, it enables you to log into your corporate intranet or IdP and then access numerous additional services, such as Salesforce, Box, or Workday, without having to re-enter your credentials. SAML is an XML-based standard for exchanging authentication and authorization data between IdPs and service providers to verify the user’s identity and permissions, then grant or deny their access to services.