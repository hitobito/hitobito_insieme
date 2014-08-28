class TimeRecord < ActiveRecord::Base

  belongs_to :group


  validates :year, uniqueness: { scope: [:group_id] }

  def lufeb
    @lufeb ||= begin
      kontakte_medien.to_i +
      interviews.to_i +
      publikationen.to_i +
      referate.to_i +
      medienkonferenzen.to_i +
      informationsveranstaltungen.to_i +
      sensibilisierungskampagnen.to_i +
      auskunftserteilung.to_i +
      kontakte_meinungsbildner.to_i +
      beratung_medien.to_i +

      eigene_zeitschriften.to_i +
      newsletter.to_i +
      informationsbroschueren.to_i +
      eigene_webseite.to_i +

      erarbeitung_instrumente.to_i +
      erarbeitung_grundlagen.to_i +
      projekte.to_i +
      vernehmlassungen.to_i +
      gremien.to_i +

      auskunftserteilung.to_i +
      vermittlung_kontakte.to_i +
      unterstuetzung_selbsthilfeorganisationen.to_i +
      koordination_selbsthilfe.to_i +
      treffen_meinungsaustausch.to_i +
      beratung_fachhilfeorganisationen.to_i +
      unterstuetzung_behindertenhilfe.to_i
    end
  end

  def total
    @total ||= (self.class.column_names - %w(id group_id year)).collect { |c| send(c).to_i }.sum
  end

end