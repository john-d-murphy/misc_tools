#!/usr/bin/python
"""
Little script to get YouTube RSS urls for tools like newsboat.
Helps me keep my feed a little more concentrated and updated periodically
instead of having to go to YouTube directly.
"""

import requests
import re
import sys


def get_youtube_channel_id(channel_url):
    """
    Fetches the Channel ID from a YouTube channel URL and
    constructs the RSS feed.

    Args:
        channel_url (str): The URL of the YouTube channel
        (e.g., https://www.youtube.com/@handle).

    Returns:
        tuple: (Channel ID, RSS Feed URL) or (None, None)
        if not found.
    """
    try:
        # Use a user-agent to avoid being blocked by YouTube's basic checks
        user_agent_mozilla = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
        user_agent_apple = "AppleWebKit/537.36 (KHTML, like Gecko)"
        user_agent_chrome = "Chrome/91.0.4472.124 Safari/537.36"
        headers = {
            "User-Agent": f"{user_agent_mozilla} "
            + f"{user_agent_apple} "
            + f"{user_agent_chrome}"
        }

        # Fetch the content of the page
        print(f"Fetching source code for: {channel_url}")
        response = requests.get(channel_url, headers=headers, timeout=10)
        # Raise an exception for bad status codes (4xx or 5xx)
        response.raise_for_status()

        # The Channel ID is usually present in the source as
        # "externalId":"UC..." We use a regular expression to find it.
        match = re.search(
            r'"externalId":"(UC[a-zA-Z0-9_-]{22})"',
            response.text,
        )

        found_channel_id = None
        rss_feed_url = None
        if match:
            found_channel_id = match.group(1)
            base_url = "https://www.youtube.com/feeds/videos.xml"
            rss_feed_url = f"{base_url}?channel_id={found_channel_id}"
        else:
            print("Error: Could not find 'externalId' in the page source.")
        return found_channel_id, rss_feed_url

    except requests.exceptions.RequestException as e:
        print(f"An error occurred while fetching the URL: {e}")
        return None, None


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python get_youtube_channel_id.py <youtube_channel_url>")
        print("Example: python get_youtube_channel_id.py LinusTechTips")
        sys.exit(1)

    channel_to_check = sys.argv[1]
    url_to_check = "https://www.youtube.com/@" + channel_to_check

    channel_id, rss_url = get_youtube_channel_id(url_to_check)

    print("\n--- Results ---")
    if channel_id:
        print(f"Channel ID: {channel_id}")
        print(f"RSS Feed URL: {rss_url}")
    else:
        print("Failed to retrieve the Channel ID.")
