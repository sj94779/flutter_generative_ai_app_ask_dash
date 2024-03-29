# Ask Dash Flutter Demo

## Overview

As part of the [Google Cloud Applied AI Summit](https://cloudonair.withgoogle.com/events/summit-applied-ml-summit-23?talk=t1_s5_vertexaisearchandconversation), the Flutter and Vertex AI teams collaborated with Very Good Ventures to create an AI-powered Flutter demo app, Ask Dash, using [Vertex AI Search and Conversation](https://cloud.google.com/vertex-ai-search-and-conversation) by Google Cloud.

For more information, check out our blog post:
https://medium.com/flutter/how-we-built-it-ask-dash-a-generative-ai-flutter-application-79a836ced058

## Vertex AI Search Backend Setup

A live API for dev is not provided in the source, but you can follow these steps to setup one and try for yourself in Google Cloud. Learn more about how to set up Vertex AI Search on their [website](https://cloud.google.com/vertex-ai-search-and-conversation).

To set up the Flutter app to use your API you need to make sure ApiClient has:

- `realApiEnabled` setup as `true`.
- `baseUrl` has the URL for your API.

To set up the Search backend for the demo, you'll need the following:

- A Datastore with the website you want to index
- An App to access that data
- A Cloud Function to act as an API wrapper

Alternatively, we have provided 5 sample questions hardcoded into the repo that can be used for testing the full flow and run the Flutter app locally without access to Vertex Search. Try these questions to see how the API would respond:

- What is flutter?
- What platforms does flutter support today?
- What language do you use to write flutter apps?
- How does hot reload work in flutter?


Note that it might take up to 4 hours to fully index your website.

## Create a Datastore

1. Go to the Google Cloud Console and search for "Search And Conversation"
2. On the left, select Data Stores and then New Data Store
3. For source select Website URL and enter you site info
4. Enter a name for your Datastore to finalize

Note that it might take up to 4 hours to fully index your website.

## Create an App to access your Datastore

1. Still in the Search And Conversation section, select Apps and New App
2. For type select Search and enter a name for your app and company
3. For data select the Datastore that you created already

Once your website has been indexed you should be able to search it directly from the Console. Select your App from the list of Apps and enter a question to try it out.

If the data is ready to be searched you should see a natural language answer along with a list of citations from your own website. If you get a generic negative response like "I don't know what you mean" make sure that your site has been fully indexed and it's a question which is answered somewhere on it.

## Build a Cloud Function API wrapper

1. In the Cloud Console search Cloud Functions
2. Select Create Function and enter a name
3. Python 3.11 as the runtime and paste the **insert link to function code here** into the source text editor

Your Search backend is now ready to go! To validate it's working correctly, on the Function page select Testing and enter a JSON object with format:

```JSON
{
	"search_term": "{your question here}"
}
```

If everything is set up correctly you'll see the response in the Output box, which includes a natural language summary, citations, and short summaries of all the pages it references. If there are any problems check the logs on the same page to troubleshoot.

To control access to your API you can set up authentication using Cloud IAM, but that is beyond the scope of this tutorial.
