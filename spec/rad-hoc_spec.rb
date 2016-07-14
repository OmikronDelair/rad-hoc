require 'spec_helper'

RSpec.describe RadHoc, "#run" do
  context "raw queries" do
    it "can do a simple select query" do
      track = create(:track)
      result = from_literal(
        <<-EOF
        table: tracks
        fields:
          title:
          track_number:
          id:
          album_id:
        EOF
      ).run_raw
      expect(result.length).to eq 1

      result_track = result.first
      expect(result_track['title']).to eq track.title
      expect(result_track['track_number']).to eq track.track_number
      expect(result_track['id']).to eq track.id
      expect(result_track['album_id']).to eq track.album_id
    end

    it "can handle simple associations" do
      track = create(:track)

      result = from_literal(
        <<-EOF
        table: tracks
        fields:
          album.title:
        EOF
      ).run_raw.first
      expect(result['title']).to eq track.album.title
    end

    it "can handle nested associations" do
      track = create(:track)

      result = from_literal(
        <<-EOF
        table: tracks
        fields:
          album.performer.title:
        EOF
      ).run_raw.first
      expect(result['title']).to eq track.album.performer.title
    end
  end

  context "interpreted queries" do
    it "can handle nested associations with columns that have identical names" do
      track = create(:track)

      result = from_literal(
        <<-EOF
        table: tracks
        fields:
          album.performer.title:
          album.title:
          title:
        EOF
      ).run[:data].first

      expect(result['title']).to eq track.title
      expect(result['album.title']).to eq track.album.title
      expect(result['album.performer.title']).to eq track.album.performer.title
    end

    it "can label fields automatically" do
      track = create(:track)

      labels = from_literal(
        <<-EOF
        table: tracks
        fields:
          title:
        EOF
      ).run[:labels]

      expect(labels['title']).to eq 'Title'
    end

    it "can label fields that are manually provided" do
      track = create(:track)

      labels = from_literal(
        <<-EOF
        table: tracks
        fields:
          title:
            label: "Name"
        EOF
      ).run[:labels]

      expect(labels['title']).to eq 'Name'
    end

    context "filtering" do
      it "can filter exact matches" do
        title = "My great album!"

        create(:track)
        create(:track, album: create(:album, title: title))

        results = from_literal(
          <<-EOF
          table: tracks
          fields:
            album.title:
          filter:
            - album.title:
                exactly: "#{title}"
          EOF
        ).run[:data]

        expect(results.length).to eq 1
        expect(results.first['album.title']).to eq title
      end
    end
  end
end