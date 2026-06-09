<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
  private static String escapeHtml(String value) {
    if (value == null) {
      return "";
    }

    return value
        .replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace("\"", "&quot;")
        .replace("'", "&#39;");
  }
%>
<%
  String submittedName = request.getParameter("nameInput");
  boolean submitted = "POST".equalsIgnoreCase(request.getMethod());
  String trimmedName = submittedName == null ? "" : submittedName.trim();
  String escapedName = escapeHtml(trimmedName);
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>DevOps Final Project</title>
  <style>
    body {
      margin: 0;
      font-family: Arial, Helvetica, sans-serif;
      background: #f7f7f4;
      color: #17202a;
    }

    main {
      max-width: 760px;
      margin: 0 auto;
      padding: 48px 24px;
    }

    h1 {
      margin: 0 0 16px;
      font-size: 2rem;
    }

    p {
      line-height: 1.5;
    }

    a {
      color: #005a9c;
      font-weight: 700;
    }

    form {
      display: grid;
      gap: 12px;
      margin: 28px 0;
      max-width: 420px;
    }

    label {
      font-weight: 700;
    }

    input {
      min-height: 40px;
      padding: 8px 10px;
      border: 1px solid #7b8794;
      border-radius: 4px;
      font-size: 1rem;
    }

    button {
      width: fit-content;
      min-height: 40px;
      padding: 8px 16px;
      border: 0;
      border-radius: 4px;
      background: #14532d;
      color: #ffffff;
      font-size: 1rem;
      font-weight: 700;
      cursor: pointer;
    }

    button:focus,
    input:focus,
    a:focus {
      outline: 3px solid #f59e0b;
      outline-offset: 2px;
    }

    .message {
      padding: 12px;
      border-radius: 4px;
      background: #e7f5ec;
      border: 1px solid #8cc69b;
    }

    .validation {
      padding: 12px;
      border-radius: 4px;
      background: #fff4df;
      border: 1px solid #e2a94f;
    }
  </style>
</head>
<body>
  <main>
    <h1 id="pageTitle">DevOps Final Project</h1>
    <p>This JSP page is packaged as a Maven WAR and prepared for deployment on Tomcat 8.5.</p>
    <p><a id="aboutLink" href="#about">About this app</a></p>

    <form id="nameForm" method="post" action="index.jsp">
      <label for="nameInput">Name</label>
      <input id="nameInput" name="nameInput" type="text" value="<%= escapedName %>" autocomplete="name">
      <button id="submitButton" type="submit">Submit</button>
    </form>

    <% if (submitted && !trimmedName.isEmpty()) { %>
      <p id="resultMessage" class="message">Hello, <%= escapedName %>. Your JSP form submission worked.</p>
    <% } else if (submitted) { %>
      <p id="validationMessage" class="validation">Please enter a name before submitting.</p>
    <% } %>

    <section id="about">
      <h2>About</h2>
      <p>This page is a JSP application packaged as a Maven WAR for Tomcat.</p>
    </section>
  </main>
</body>
</html>
