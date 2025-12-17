# Project Revision Notes

## 1. Project Flow

**Q: How does the data flow in this project?**
**A:**

1.  **User Visits URL**: A user enters your website URL.
2.  **CloudFront**: The request hits CloudFront first.
3.  **Frontend**: CloudFront serves the `index.html` (either from its cache or by fetching it from the S3 bucket).
4.  **JavaScript Execution**: The browser loads the page and runs the `script.js` code.
5.  **API Call**: The browser sends a new request to `/api/views` (e.g., `https://your-site.com/api/views`).
6.  **CloudFront Logic**: CloudFront sees the `/api/*` path and recognizes it shouldn't be cached. It forwards this request to the Lambda Function URL.
7.  **Database**: Lambda updates the count in DynamoDB and returns the new number.
8.  **Update UI**: The browser receives the number and updates the text on the screen.

## 2. CloudFront

**Q: Why do we need CloudFront and what does it do?**
**A:**
CloudFront is a **Content Delivery Network (CDN)**.

1.  **Speed (Caching)**: It stores copies of your website (HTML, CSS, JS) in servers all around the world (Edge Locations). When a user in London visits your site, they get the file from a London server, not your main S3 bucket in the US.
2.  **Security (HTTPS)**: It gives you a secure HTTPS connection automatically.
3.  **Routing**: It acts as a traffic director. It sends normal web traffic to S3 and API traffic to Lambda, all under one single domain name.

## 3. Caching Methods

**Q: Why do we need 2 different caching behaviors?**
**A:**
We have two different types of content:

1.  **Static Content (Frontend)**: This _never_ changes for a specific version. We want to cache this aggressively so it loads instantly for everyone. (Behavior: `default_cache_behavior`)
2.  **Dynamic Content (API)**: This _always_ changes (the view count goes up every second). We must **NEVER** cache this. If we cached it, the user would see an old view count (like "Views: 5") forever. (Behavior: `ordered_cache_behavior` for `/api/*`)

## 4. Lambda Code Usage

**Q: What does the Lambda code actually do?**
**A:**
The Python script (`lambda.py`) is the "brain" of the counter.

1.  **Setup**: It connects to DynamoDB using the `boto3` library.
2.  **Update**: When triggered, it runs an `update_item` command on your database table.
3.  **Atomic Counter**: It uses a special feature `SET views = views + 1` to safely add 1 to the count, even if 100 people visit at the exact same millisecond.
4.  **Return**: It grabs the new, updated number and sends it back as a JSON response (e.g., `{"views": 105}`).

## 5. Lambda URL

**Q: Why do we need a Lambda URL?**
**A:**
Normally, Lambda functions are private and can't be reached from the internet.
To call them from a browser, we usually need an **API Gateway**, which costs money and is complex to set up.
**Lambda URL** is a simpler, cheaper alternative that gives the function a public HTTP endpoint (like `https://...aws_lambda_url...`) so CloudFront can talk to it directly.
