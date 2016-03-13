package com.malalaoshi.android.course;

import android.content.Context;
import android.graphics.Color;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.widget.GridView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.malalaoshi.android.R;
import com.malalaoshi.android.adapter.MalaBaseAdapter;
import com.malalaoshi.android.entity.CourseDateEntity;

import java.util.ArrayList;
import java.util.List;

import butterknife.Bind;
import butterknife.ButterKnife;

/**
 * Course date choice view
 * Created by tianwei on 3/6/16.
 */
public class CourseDateChoiceView extends LinearLayout {

    public interface OnCourseDateChoiceListener {
        void onCourseDateChoice(List<Long> sections);
    }

    private OnCourseDateChoiceListener listener;
    private List<CourseDateEntity> dateList;
    @Bind(R.id.grid_view)
    protected GridView gridView;

    @Bind(R.id.tv_section1)
    protected TextView section1;
    @Bind(R.id.tv_section2)
    protected TextView section2;
    @Bind(R.id.tv_section3)
    protected TextView section3;
    @Bind(R.id.tv_section4)
    protected TextView section4;
    @Bind(R.id.tv_section5)
    protected TextView section5;

    private GridViewAdapter adapter;

    public CourseDateChoiceView(Context context, AttributeSet attrs) {
        super(context, attrs);
        View view = View.inflate(context, R.layout.view_course_date_choice, null);
        addView(view);
        ButterKnife.bind(this, view);
        dateList = new ArrayList<>();
        adapter = new GridViewAdapter(context);
        gridView.setAdapter(adapter);
    }

    public void setData(List<CourseDateEntity> list) {
        adapter.clear();
        adapter.addAll(list);
        adapter.notifyDataSetChanged();
        section1.setText(getSectionTitle(list.get(0)));
        section2.setText(getSectionTitle(list.get(7)));
        section3.setText(getSectionTitle(list.get(14)));
        section4.setText(getSectionTitle(list.get(21)));
        section5.setText(getSectionTitle(list.get(28)));
    }

    private String getSectionTitle(CourseDateEntity entity) {
        return entity.getStart() + "\n" + entity.getEnd();
    }

    public void setOnCourseDateChoiceListener(OnCourseDateChoiceListener listener) {
        this.listener = listener;
    }

    private class GridViewAdapter extends MalaBaseAdapter<CourseDateEntity> {
        public GridViewAdapter(Context context) {
            super(context);
        }

        @Override
        protected View createView(int position, ViewGroup parent) {
            return View.inflate(context, R.layout.view_course_date_choice_item, null);
        }

        public void choiceChanged() {
            List<Long> list = new ArrayList<>();
            for (CourseDateEntity entity : getList()) {
                if (entity.isChoice()) {
                    list.add(entity.getId());
                }
            }
            if(listener!=null){
                listener.onCourseDateChoice(list);
            }
        }

        @Override
        protected void fillView(int position, final View convertView, final CourseDateEntity data) {
            if (data.isAvailable()) {
                if (data.isChoice()) {
                    convertView.setBackgroundColor(convertView.getContext().getResources().getColor(R.color.theme_blue_light));
                } else {
                    convertView.setBackgroundColor(Color.TRANSPARENT);
                }
            } else {
                convertView.setBackgroundColor(Color.parseColor("#ededed"));
            }
            convertView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (!data.isAvailable()) {
                        return;
                    }
                    data.setChoice(!data.isChoice());
                    choiceChanged();
                    notifyDataSetChanged();
                }
            });
        }
    }
}
