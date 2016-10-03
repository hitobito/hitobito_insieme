# encoding: utf-8
# == Schema Information
#
# Table name: time_records
#
#  id                                       :integer          not null, primary key
#  group_id                                 :integer          not null
#  year                                     :integer          not null
#  verwaltung                               :integer
#  beratung                                 :integer
#  treffpunkte                              :integer
#  blockkurse                               :integer
#  tageskurse                               :integer
#  jahreskurse                              :integer
#  kontakte_medien                          :integer
#  interviews                               :integer
#  publikationen                            :integer
#  referate                                 :integer
#  medienkonferenzen                        :integer
#  informationsveranstaltungen              :integer
#  sensibilisierungskampagnen               :integer
#  auskunftserteilung                       :integer
#  kontakte_meinungsbildner                 :integer
#  beratung_medien                          :integer
#  eigene_zeitschriften                     :integer
#  newsletter                               :integer
#  informationsbroschueren                  :integer
#  eigene_webseite                          :integer
#  erarbeitung_instrumente                  :integer
#  erarbeitung_grundlagen                   :integer
#  projekte                                 :integer
#  vernehmlassungen                         :integer
#  gremien                                  :integer
#  vermittlung_kontakte                     :integer
#  unterstuetzung_selbsthilfeorganisationen :integer
#  koordination_selbsthilfe                 :integer
#  treffen_meinungsaustausch                :integer
#  beratung_fachhilfeorganisationen         :integer
#  unterstuetzung_behindertenhilfe          :integer
#  mittelbeschaffung                        :integer
#  allgemeine_auskunftserteilung            :integer
#  type                                     :string(255)      not null
#  total_lufeb_general                      :integer
#  total_lufeb_private                      :integer
#  total_lufeb_specific                     :integer
#  total_lufeb_promoting                    :integer
#  nicht_art_74_leistungen                  :integer
#


#  Copyright (c) 2012-2014, insieme Schweiz. This file is part of
#  hitobito_insieme and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_insieme.

require 'spec_helper'

describe TimeRecordsController do
  let(:group) { groups(:dachverein) }

  it 'raises 404 for unsupported group type' do
    sign_in(people(:top_leader))
    expect do
      get :edit, id: groups(:kommission74).id, year: 2014, report: 'employee_time'
    end.to raise_error(CanCan::AccessDenied)
  end

  it 'raises 404 for unsupported report type' do
    sign_in(people(:top_leader))
    expect do
      get :edit, id: group.id, year: 2014, report: 'employee_tux'
    end.to raise_error(ActionController::RoutingError)
  end

  context 'authorization' do
    it 'top leader is allowed to update dachverein' do
      sign_in(people(:top_leader))
      get :edit, id: group.id, year: 2014, report: 'employee_time'
      expect(response).to be_ok
    end

    it 'regio leader is not allowed to update dachverein' do
      expect do
        sign_in(people(:regio_leader))
        get :edit, id: group.id, year: 2014, report: 'employee_time'
      end.to raise_error(CanCan::AccessDenied)
    end
  end

  context '#index' do

    before { sign_in(people(:top_leader)) }

    it 'shows basic info' do
      get :index, id: group.id, year: 2014
      expect(response.status).to eq(200)
    end
  end

  context '#edit' do
    before { sign_in(people(:top_leader)) }

    it 'builds new time_record based on group and year' do
      get :edit, id: group.id, year: 2014, report: 'employee_time'
      expect(response.status).to eq(200)

      expect(assigns(:record)).not_to be_persisted
      expect(assigns(:record).group).to eq group
      expect(assigns(:record).year).to eq 2014
    end

    it 'reuses existing time_record based on group and year' do
      record = TimeRecord::EmployeeTime.create!(group: group, year: 2014)
      get :edit, id: group.id, year: 2014, report: 'employee_time'
      expect(assigns(:record)).to eq record
      expect(assigns(:record)).to be_persisted
    end

    it 'builds nested employee pensum' do
      get :edit, id: group.id, year: 2014, report: 'employee_time'
      expect(response.status).to eq(200)

      expect(assigns(:record).employee_pensum).to be
    end

    it 'supports other volunteer report types' do
      get :edit, id: group.id, year: 2014, report: 'volunteer_without_verification_time'
      expect(response.status).to eq(200)

      get :edit, id: group.id, year: 2014, report: 'volunteer_with_verification_time'
      expect(response.status).to eq(200)
    end
  end

  context '#update' do
    before { sign_in(people(:top_leader)) }

    let(:attrs) do
      {
        kontakte_medien: 10,
        interviews: 10,
        publikationen: 10,
        referate: 10,
        medienkonferenzen: 10,
        informationsveranstaltungen: 10,
        sensibilisierungskampagnen: 10,
        kontakte_meinungsbildner: 10,
        beratung_medien: 10,

        eigene_zeitschriften: 10,
        newsletter: 10,
        informationsbroschueren: 10,
        eigene_webseite: 10,

        erarbeitung_instrumente: 10,
        erarbeitung_grundlagen: 10,
        projekte: 10,
        vernehmlassungen: 10,
        gremien: 10,

        auskunftserteilung: 10,
        vermittlung_kontakte: 10,
        unterstuetzung_selbsthilfeorganisationen: 10,
        koordination_selbsthilfe: 10,
        treffen_meinungsaustausch: 10,
        beratung_fachhilfeorganisationen: 10,
        unterstuetzung_behindertenhilfe: 10,

        employee_pensum_attributes: {
          paragraph_74: 10,
          not_paragraph_74: 10
        }
      }
    end

    it 'assigns all permitted params' do
      expect do
        put :update, id: group.id, year: 2014, report: 'employee_time', time_record: attrs
      end.to change { TimeRecord.count }.by(1)

      expect(assigns(:record).kontakte_medien).to eq(10)
      expect(assigns(:record).employee_pensum.paragraph_74).to eq(10)
    end
  end
end
