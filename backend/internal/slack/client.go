package slack

import (
	"context"

	"github.com/slack-go/slack"
	"golang.org/x/xerrors"
)

// NewClient - Slack クライアントを初期化する
func NewClient(token, teamName string) *Client {
	return &Client{
		client: slack.New(token),
	}
}

// Client - Slackのクライアントライブラリのラッパー
type Client struct {
	teamName string
	client   *slack.Client
}

// InviteToTeam - 新規メンバーをSlackに招待する
func (c *Client) InviteToTeam(ctx context.Context, firstName, lastName, emailAddress string) error {
	if err := c.client.InviteToTeamContext(ctx, c.teamName, firstName, lastName, emailAddress); err != nil {
		return xerrors.Errorf("failed to send invitation via slack API to %s: %w", emailAddress, err)
	}

	return nil
}
